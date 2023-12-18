import express from 'express'
import bodyParser from 'body-parser'
import { MongoClient, ObjectId } from 'mongodb'
import { createClient } from 'redis'
import { collectDefaultMetrics, Counter, register } from 'prom-client'
import promBundle from 'express-prom-bundle'
import winston from 'winston'
import LokiTransport from 'winston-loki'

import { config } from 'dotenv';

config();

const {
  MONGO_USER,
  MONGO_PASSWORD,
  MONGO_HOST,
  MONGO_PORT,
  MONGO_DB,
  EXPRESS_PORT,
  DOCKER_MONGO_PORT,
  LOKI_PORT,
  REDIS_PORT
} = process.env;

const REDIS_HOST = process.env.REDIS_HOST ?? 'localhost'
const LOKI_HOST = process.env.LOKI_HOST ?? 'localhost'

const logger = winston.createLogger({
    level: 'debug',
    format: winston.format.json(),
    transports: [
        new winston.transports.Console(),
        new LokiTransport({ host: `http://${LOKI_HOST}:${LOKI_PORT}`, json: true, labels: { job: 'node-express' } })
    ]
})

collectDefaultMetrics({ register })
const metricsMiddleware = promBundle({
    includeMethod: true,
    includePath: true,
    metricType: 'summary',
    percentiles: []
})

const artefactCounter = new Counter({
    name: 'artefact_requests_counter',
    help: 'Requests of explorers by artefact',
    labelNames: ['artefact']
})

const client = new MongoClient(`mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${DOCKER_MONGO_PORT}`);
const db = client.db(MONGO_DB);

const redisClient = await createClient({ url: `redis://${REDIS_HOST}:${REDIS_PORT}` })
    .on('error', err => logger.error('Redis Client Error', err))
    .connect()

const app = express();
app.use(bodyParser.json());
app.use(metricsMiddleware);
const appPort = EXPRESS_PORT;

app.get('/', (_, res) => {
    res.send('')
})

app.get('/explorer', async (req, res) => {
    try {
        const { artefact } = req.query

        logger.debug(`Explorers for artefact ${artefact} requested`)
        artefactCounter.labels({ artefact: artefact }).inc()

        const cachedExplorers = JSON.parse(await redisClient.get('explorer:' + artefact))

        if (cachedExplorers) {
            logger.debug(`Got explorers for artefact ${artefact} from cache`)

            if (cachedExplorers.length === 0) res.status(404)
            return res.json(cachedExplorers)
        }

        logger.debug(`No explorers for artefact ${artefact} in cache`)

        const explorers_artefacts = await db
            .collection('explorer')
            .find({artefacts: new ObjectId(artefact)}, { limit: 10, sort: { _id: -1 } })
            .toArray()

        redisClient.set('explorer:' + artefact, JSON.stringify(explorers_artefacts), { EX: 10 })

        logger.debug(`Added explorers for artefact ${artefact} in cache`)

        if (explorers_artefacts.length === 0) res.status(404)

        res.json(explorers_artefacts)
    } catch (err) {
        console.log(err)
        res.sendStatus(400)
    }
})

app.post('/explorer/create', async (req, res) => {
    try {
        const { name, age, country, artefact } = req.body
        const artefacts = artefact.map(item => new ObjectId(item));
        console.log(artefacts)
        const { insertedId } = await db
            .collection('explorer')
            .insertOne({ name, age, country, artefacts })

        res.json({ id: insertedId })
    } catch (err) {
        console.log(err)
        res.sendStatus(400)
    }
})

app.post('/explorer/update', async (req, res) => {
    try {
        const { id, name, age, country, artefact } = req.body
        const artefacts = artefact.map(item => new ObjectId(item));
        const result = await db
            .collection('explorer')
            .updateOne(
                { _id: new ObjectId(id) },
                { $set: { name, age, country, artefacts } }
            )

        if (result.matchedCount === 0) {
            res.sendStatus(404)
        } else {
            res.sendStatus(204)
        }
    } catch (err) {
        console.log(err)
        res.sendStatus(400)
    }
})

app.delete('/explorer/delete', async (req, res) => {
    try {
        const { id } = req.body
        const { deletedCount } = await db.collection('explorer').deleteOne({ _id: new ObjectId(id) })

        if (deletedCount === 0) {
            res.sendStatus(404)
        } else {
            res.sendStatus(204)
        }
    } catch (err) {
        console.log(err)
        res.sendStatus(400)
    }
})



app.get('/artefact', async (_, res) => {
    try {
        const artefacts = await db
            .collection('artefact')
            .find({}, { limit: 10, sort: { _id: -1 } })
            .toArray();

        res.json(artefacts);
    } catch (err) {
        console.log(err);
        res.sendStatus(400);
    }
});

app.post('/artefact/create', async (req, res) => {
    try {
        const { title, description, creator } = req.body;
        const { insertedId } = await db
            .collection('artefact')
            .insertOne({ title, description, creator });

        res.json({ id: insertedId });
    } catch (err) {
        console.log(err);
        res.sendStatus(400);
    }
});

app.post('/artefact/update', async (req, res) => {
    try {
        const { id, title, description, creator } = req.body;
        const result = await db
            .collection('artefact')
            .updateOne(
                { _id: new ObjectId(id) },
                { $set: { title, description, creator } }
            );

        if (result.matchedCount === 0) {
            res.sendStatus(404);
        } else {
            res.sendStatus(204);
        }
    } catch (err) {
        console.log(err);
        res.sendStatus(400);
    }
});

app.delete('/artefact/delete', async (req, res) => {
    try {
        const { id } = req.body;
        const { deletedCount } = await db.collection('artefact').deleteOne({ _id: new ObjectId(id) });

        if (deletedCount === 0) {
            res.sendStatus(404);
        } else {
            res.sendStatus(204);
        }
    } catch (err) {
        console.log(err);
        res.sendStatus(400);
    }
});

app.get('/explorer_artefact', async (_, res) => {
    try {
        const aggregation = await db.collection('explorer').aggregate([
            {
                $lookup: {
                    from: "artefact",
                    localField: "artefacts",
                    foreignField: "_id",
                    as: "artefact_info"
                }
            }
        ]).toArray();

        res.json(aggregation);
    } catch (err) {
        console.log(err);
        res.sendStatus(400);
    }
});

app.get('/artefact_explorer', async (_, res) => {
    try {
        const aggregation = await db.collection('artefact').aggregate([
            {
                $lookup: {
                    from: "explorer",
                    localField: "_id",
                    foreignField: "artefacts",
                    as: "explorer_info"
                }
            }
        ]).toArray();

        res.json(aggregation);
    } catch (err) {
        console.log(err);
        res.sendStatus(400);
    }
});



app.listen(appPort, () => {
    console.log(`app listening on port ${appPort}`)
})
