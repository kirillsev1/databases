import express from 'express'
import bodyParser from 'body-parser'
import { MongoClient, ObjectId } from 'mongodb'
import { config } from 'dotenv'

config()

const { MONGO_USER, MONGO_PASSWORD, MONGO_HOST, MONGO_PORT, MONGO_DB, EXPRESS_PORT, DOCKER_MONGO_PORT } = process.env

const client = new MongoClient(`mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${DOCKER_MONGO_PORT}`)
const db = client.db(MONGO_DB)

const app = express()
app.use(bodyParser.json())
const appPort = EXPRESS_PORT

app.get('/', (_, res) => {
    res.send('')
})

app.get('/expedition', async (_, res) => {
    try {
        const movies = await db
            .collection('expedition')
            .find({}, { limit: 10, sort: { _id: -1 } })
            .toArray()

        res.json(movies)
    } catch (err) {
        console.log(err)
        res.sendStatus(400)
    }
})

app.post('/expedition/create', async (req, res) => {
    try {
        const { title, year, country } = req.body
        const { insertedId } = await db
            .collection('expedition')
            .insertOne({ title, year, country })

        res.json({ id: insertedId })
    } catch (err) {
        console.log(err)
        res.sendStatus(400)
    }
})

app.post('/expedition/update', async (req, res) => {
    try {
        const { id, title, year, country } = req.body
        const result = await db
            .collection('expedition')
            .updateOne(
                { _id: new ObjectId(id) },
                { $set: { title, year, country } }
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

app.delete('/expedition/delete', async (req, res) => {
    try {
        const { id } = req.body
        const { deletedCount } = await db.collection('expedition').deleteOne({ _id: new ObjectId(id) })

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

app.listen(appPort, () => {
    console.log(`app listening on port ${appPort}`)
})
