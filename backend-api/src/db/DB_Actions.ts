import {Context, MCQ, MCQOption, Question, QuestionInformation, QuestionType, Session} from "./DB_Types";
import {Pool, ResultSetHeader, RowDataPacket} from "mysql2/promise";
import {get_text_embedding} from "../ibm/IBM_Actions";

// Select MCQ by level
// Reason: Fetch MCQ table linked to specific level
// Inputs: Database, level
// Output: MCQ question
export const getMCQByLevel = async (db: Pool, level: number): Promise<Question[]> => {
    try {
        const [results] = await db.query("SELECT * FROM Question WHERE type = 'MCQ' AND level = ?", [level]);
        return results as Question[];
    } catch (error) {
        console.error("Error fetching MCQ by level", error);
        throw error;
    }
};

// Select EssayQ by level
// Reason: Fetch EssayQ table linked to specific level
// Inputs: Database, level
// Output: EssayQ question
export const getEssayByLevel  = async (db: Pool, level: number): Promise<any[] | null> => {
    try {
        const [results] = await db.query("SELECT * FROM Question WHERE type = 'EssayQ' AND level = ?", [level]);
        return results as Question[];
    } catch (error) {
        console.error("Error fetching EssayQ by level", error);
        throw error;
    }
};

// Select question options by id
// Reason: Fetch MCQ Answer table linked to specific question
// Inputs: Database, id
// Output: MCQ options
export const getQuestionTextById = async (db: Pool, id: number): Promise<Question[] | null> => {
    try {
        const [results]: any = await db.query("SELECT text FROM Question WHERE id = ?", [id]);
        return results[0]?.text || null;
    } catch (error) {
        console.error("Error fetching MCQA by ID:", error);
        throw error;
    }
};

// Select correct answer by ID
// Reason: Fetch correct answer for each question
// Inputs: Database, id
// Output: Answer
export const getCorrectAnswerById = async (db: Pool, id: number): Promise<string | string[] | null> => {
    try{
        const [results]: any = await db.query("SELECT correctAnswer FROM Question WHERE id = ?", [id]);
        return results[0]?.correctAnswer || null;
    }catch (error) {
        console.error("Error fetching MCQA by ID:", error);
        throw error;
    }
};


// Select KP by Question ID
// Reason: Fetch KP table linked to MCQ questions
// Inputs: Database, id
// Output: Knowledge point
export const getKpById = async (db: Pool, id: number): Promise<number | null> => {
    try{
        const [results]: any = await db.query("SELECT kp FROM Question WHERE id = ?", [id]);
        return results[0]?.kp || null;
    }catch (error) {
        console.error("Error fetching KP by ID:", error);
        throw error;
    }
};

// Select context text by Question ID
// Reason: Fetch context needed to answer all the question in a level
// Inputs: Database, level
// Output: Context
export const getContextByLevel = async (db: Pool, level: number): Promise<Context[]> => {
    try{
        const [results] = await db.query("SELECT * FROM Context WHERE level = ?", [level]);
        return results as Context[];
    }catch (error) {
        console.error("Error fetching EssayA by ID:", error);
        throw error;
    }
};

export type fullEmbed = {
    id: number;
    embedding: string;
    text: string;
}

export async function get_full_embedding(db: Pool, embedding_id: number): Promise<fullEmbed | null> {
    try {
        const [results, fields] = await db.query(
            `SELECT *
            FROM Embeddings
            WHERE id = ?`,
            [embedding_id]
        )

        const res = results as RowDataPacket[]

        if (res.length != 1) {
            console.log("Found non-unique value when searching for embed")
            return null
        }

        return res[0]
    } catch (err) {
        console.log(err)
        return null
    }
}

export async function get_embedding(db: Pool, embedding_id: number): Promise<string | null> {
    try {
        const [results, fields] = await db.query(
            `SELECT embedding
             FROM Embeddings
             WHERE id = ?`,
            [embedding_id]
        )

        const res = results as RowDataPacket[]

        if (res.length != 1) {
            console.log("Found non-unique value when searching for embed")
            return null
        }

        return res[0].embedding
    } catch (err) {
        console.log(err)
        return null
    }
}

export async function create_embedding(db: Pool, text: string): Promise<number | null>  {
    try {
        text = text.replace(/[^A-Za-z0-9 .,?!;:()&]/g, '');

        const text_embedding = await get_text_embedding(text)

        if (text_embedding === null) return null

        const [results, fields] = await db.query(
            "INSERT INTO Embeddings(embedding, text) VALUES(VEC_FromText('[?]'), \"?\")",
            [text_embedding, text]
        )

        return (results as ResultSetHeader).insertId
    } catch (err) {
        console.log(err)
        return null
    }
}

export async function embed_distance(db: Pool, embed_id_1: number, embed_id_2: number): Promise<number | null> {
    try {
        const [results, fields] = await db.query(
            `SELECT VEC_DISTANCE_COSINE(a.embedding, b.embedding) as distance
            FROM Embeddings a, Embeddings b
            WHERE a.id = ? AND b.id = ?`,
            [embed_id_1, embed_id_2]
        )

        let r = results as RowDataPacket

        if (r.length != 1) return null

        return r[0].distance
    } catch (err) {
        console.log(err)
        return null
    }
}

export async function get_session(db: Pool, sessionID: string): Promise<Session | null> {
    try {
        const [results, fields] = await db.query(
            "SELECT * FROM Session WHERE Session.sessionID = ?",
            [sessionID]
        )

        let res = results as Session[]

        if (res.length == 1) {
            return res[0]
        }

        if (res.length == 0) {
            console.log("No session found")
            return null
        }

        console.log("DevErr: found multiple session results from unique sessionID")
        return null
    } catch (err) {
        console.log("Error when getting session")
        return null
    }
}

export async function insert_session(db: Pool, session: Session): Promise<boolean> {
    try {
        const [results, fields] = await db.query(
            "INSERT INTO Session VALUES(?, ?, ?, ?, ?)",
            [session.sessionID, session.score, session.from, session.to, 0]
        )

        const res = results as ResultSetHeader

        return res.affectedRows == 1;
    } catch (err) {
        console.log(err)
        return false;
    }
}

export async function remove_session(db: Pool, sessionID: string): Promise<boolean> {
    try {
        const [results, fields] = await db.query(
            "DELETE FROM Session WHERE Session.SessionID = ?",
            [sessionID]
        )

        const res = results as ResultSetHeader

        return res.affectedRows == 1;
    } catch (err) {
        console.log(err)
        return false
    }
}

export async function get_level_questions(db: Pool, lvl: number): Promise<Question[]> {
    try {
        const [results, fields] = await db.query(
            "SELECT * FROM Question WHERE Question.level = ? ORDER BY Question.id",
            [lvl]
        )

        return results as Question[]
    } catch (err) {
        console.log(err)
        return []
    }
}


export async function get_level_questions_and_options(db: Pool, lvl: number): Promise<QuestionInformation[] | null> {
    let qs: Question[] = await get_level_questions(db, lvl)

    if (qs.length === 0) return null

    let infos: QuestionInformation[] = []
    for (const q of qs) {
        let info: QuestionInformation = {question: q, options: ""}

        switch (q.type) {
            case QuestionType.MCQ:
                info.options = await get_mcq_options_by_id(db, q.id)
                break
            case QuestionType.EssayQ:
                info.options = ""
                break
        }

        infos.push(info)
    }

    return infos
}

export async function get_question_by_id(db: Pool, id: number): Promise<Question | null> {
    try {
        const [results, fields] = await db.query(
            "SELECT * FROM Question WHERE Question.id = ?",
            [id]
        );

        let qs = results as Question[]

        if (qs.length === 1) return qs[0];

        if (qs.length === 0) {
            return null;
        }

        console.log("DevErr")
        return null;
    } catch (err) {
        return null;
    }
}

export async function get_mcq_options_by_id(db: Pool, id: number): Promise<MCQOption[]> {
    try {
        const [results, fields] = await db.query(
            "SELECT text FROM Question WHERE id = ?",
            [id]
        );

        return results as MCQOption[]
    } catch (err) {
        console.log(err)
        return []
    }
}

export async function get_mcq_question_answer_by_id(db: Pool, id: number): Promise<number | null> {
    try {
        const [results, fields] = await db.query(
            "SELECT answerIdx FROM MCQAnswer WHERE questionID = ?",
            [id]
        );

        if (results.length != 1) {
            return null;
        }

        return results[0].answerIdx
    } catch (err) {
        console.log(err)
        return null;
    }
}