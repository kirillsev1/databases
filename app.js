import express from 'express'
import bodyParser from 'body-parser'
import { Client } from '@elastic/elasticsearch'

const client = new Client({
    node: 'http://localhost:41554'
})

const app = express()
app.use(bodyParser.json())
const appPort = 3000

app.get('/', (_, res) => {
    res.send('')
})

app.get('/explorer', async (req, res) => {
    try {
        const text = req.query['text']

        const result = await client.search({
            index: 'explorer',
            query: {
                match: {
                    plot: {
                        query: text
                    }
                }
            }
        })

        res.json(result.hits.hits)
    } catch (err) {
        console.log(err)
        res.sendStatus(400)
    }
})

app.listen(appPort, () => {
    console.log(`app listening on port ${appPort}`)
})
