import * as dotenv from "dotenv";
import express, { Request, Response } from "express";
import * as http from "http";
import mysql, { Pool } from "mysql2/promise";

import {
    getMCQByLevel,
    getEssayByLevel,
    getQuestionTextById,
    getCorrectAnswerById,
    getKpById,
    getContextByLevel, create_embedding, embed_distance, get_mcq_question_answer_by_id, get_question_by_id
} from "./db/DB_Actions";

import {Question, QuestionType} from "./db/DB_Types";
import {HttpStatusCode} from "axios";

dotenv.config();

let cookies = require("cookie-parser");

const app = express();
app.use(express.json());
app.use(cookies());

const httpServer = http.createServer(app);

const db = mysql.createPool({
    host: "localhost",
    user: process.env.DB_ROOT_USERNAME,
    password: process.env.DB_ROOT_PWORD,
    database: process.env.DB_DB,
    connectionLimit: 10,
    authPlugins: {
        auth_gssapi_client: () => () => Buffer.from(process.env.DB_ROOT_PWORD || "")
    }
});

app.get("/questions/mcq", async (req: Request, res: Response) => {
    try {
        const level = parseInt(req.query.level as string);
        if (isNaN(level)) return res.status(400).json({ error: "Invalid level" });
        const questions = await getMCQByLevel(db, level);
        res.json(questions);
    } catch (err) {
        res.status(500).json({ error: "Internal Server Error" });
    }
});

app.get("/questions/essay", async (req: Request, res: Response) => {
    try {
        const level = parseInt(req.query.level as string);
        if (isNaN(level)) return res.status(400).json({ error: "Invalid level" });
        const questions = await getEssayByLevel(db, level);
        res.json(questions);
    } catch (err) {
        res.status(500).json({ error: "Internal Server Error" });
    }
});

app.get("/question/text/:id", async (req: Request, res: Response) => {
    try {
        const id = parseInt(req.params.id);
        const text = await getQuestionTextById(db, id);
        res.json({ text });
    } catch (err) {
        res.status(500).json({ error: "Internal Server Error" });
    }
});

app.get("/question/answer/:id", async (req: Request, res: Response) => {
    try {
        const id = parseInt(req.params.id);
        const answer = await getCorrectAnswerById(db, id);
        res.json({ correctAnswer: answer });
    } catch (err) {
        res.status(500).json({ error: "Internal Server Error" });
    }
});

app.get("/question/kp/:id", async (req: Request, res: Response) => {
    try {
        const id = parseInt(req.params.id);
        const kp = await getKpById(db, id);
        res.json({ kp });
    } catch (err) {
        res.status(500).json({ error: "Internal Server Error" });
    }
});

app.get('/question/header/:questionID', async (req: Request, res: Response) => {
    const questionID: number = Number(req.params.questionID)

    if (!questionID) {
        res.status(HttpStatusCode.BadRequest).json({
            err: "No question id provided"
        })
        return;
    }

    let q: Question | null = await get_question_by_id(db, questionID);

    if (q == null) {
        res.status(HttpStatusCode.NotFound).json({
            err: "Could not find question"
        })
        return;
    } else {
        res.status(HttpStatusCode.Ok).json({
            data: {
                id: q.id,
                question: q.question,
                text: q.text,
                type: q.type
            }
        })
    }
})

app.get("/context", async (req: Request, res: Response) => {
    try {
        const level = parseInt(req.query.level as string);
        if (isNaN(level)) return res.status(400).json({ error: "Invalid level" });
        const context = await getContextByLevel(db, level);
        res.json(context);
    } catch (err) {
        res.status(500).json({ error: "Internal Server Error" });
    }
});

async function mark_essay(res: Response, question: Question, user_answer: string) {
    let sample: string = JSON.parse(question.correctAnswer)[0]

    console.log("USER: ", user_answer)
    console.log("SAMPLE: ", sample)
    const user_embedding_id: number|null = await create_embedding(db, user_answer)

    if (!user_embedding_id) {
        res.status(HttpStatusCode.InternalServerError).json({
            err: "Unable to create embedding of given answer"
        })
        return
    }

    // todo store embeddings beforehand, change correct answer format
    const sample_embedding_id: number|null = await create_embedding(db, sample)

    if (!sample_embedding_id) {
        res.status(HttpStatusCode.InternalServerError).json({
            err: "Unable to create embedding of sample answer"
        })
        return
    }

    const distance: number|null = await embed_distance(db, user_embedding_id, sample_embedding_id)

    if (!distance) {
        res.status(HttpStatusCode.InternalServerError).json({
            err: "Unable to calculate vector distance"
        })
        return
    }

    console.log("DIST: ", distance)

    res.status(HttpStatusCode.Ok).json({
        data: {
            type: "EssayQ",
            mark: distance <= 0.2,
            kp: question.kp,
            sample_answers: question.correctAnswer,
            dist: distance
        }
    })
}

async function mark_mcq(res: Response, question: Question, user_answer: string) {
    const correct_answer = await get_mcq_question_answer_by_id(db, question.id)

    try {
        const user_choice = parseInt(user_answer)

        res.status(HttpStatusCode.Ok).json({
            data: {
                type: "MCQ",
                mark: correct_answer === user_choice,
                kp: question.kp
            }
        })
    } catch (parse_error) {
        res.status(HttpStatusCode.BadRequest).json({
            err: "Expected numeric answer for MCQ"
        })
    }
}

app.post('/question/mark', async (req: Request, res: Response) => {
    console.log(req.body)
    const userAnswer: string|null = req.body.answer;
    const questionID: number|null = req.body.questionID;

    console.log(userAnswer, questionID)

    if (userAnswer === null || questionID === null) {
        res.status(HttpStatusCode.BadRequest).json({
            err: "No answer or questionID found in POST request"
        })
        return
    }

    const question = await get_question_by_id(db, questionID)

    if (!question) {
        res.status(HttpStatusCode.NotFound).json({
            err: `No question found with id ${questionID}`
        })
        return
    }

    if (question.type === QuestionType.EssayQ) {
        await mark_essay(res, question, userAnswer)
    } else if (question.type === QuestionType.MCQ) {
        await mark_mcq(res, question, userAnswer)
    } else {
        res.status(HttpStatusCode.ExpectationFailed).json({
            err: "Unexpected question type found in the database"
        })
        return
    }
})

const PORT = process.env.PORT || 7001;
httpServer.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
