import * as dotenv from "dotenv";
dotenv.config({path: '/var/www/ibm/api/.env'});

let api_key = process.env.API_KEY
let project_id = process.env.PROJECT_ID

export async function authenticate(): Promise<string | null> {
    if (!api_key || !project_id) {
        console.log("api key and project id are required environment variables, have a .env file with them and use `node --env-file=.env` src/index.js")
        return null
    }
    try {
        let res = await fetch(
            "https://iam.cloud.ibm.com/identity/token",
            {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                method: 'POST',
                body: new URLSearchParams({
                    grant_type: 'urn:ibm:params:oauth:grant-type:apikey',
                    apikey: api_key
                })
            }
        )

        let json = await res.json()
        return json.access_token
    } catch (err) {
        console.log("Unable to authenticate: ", err)
        return null
    }
}

export async function get_text_embedding(text: string): Promise<string | null> {
    const access_token = await authenticate()

    if (access_token === null) return null

    try {
        let chat_json = await fetch(
            "https://eu-gb.ml.cloud.ibm.com/ml/v1/text/embeddings?version=2024-05-01",
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': `Bearer ${access_token}`
                },
                method: 'POST',
                body: JSON.stringify({
                    inputs: [text],
                    parameters: {
                        "truncate_input_tokens": 512,
                    },
                    model_id: 'ibm/slate-125m-english-rtrvr-v2',
                    project_id: project_id
                })
            }
        ).then(async (res) => await res.json()
        ).then((json) => json)

        return chat_json.results[0].embedding
    } catch (err) {
        console.log(err)
        return null
    }
}