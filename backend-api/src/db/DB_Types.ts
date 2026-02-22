export enum QuestionType {
    MCQ="MCQ",
    EssayQ="EssayQ"
}

export type Context = {
    id: number;
    text: string;
    level: number;
};

export type Question = {
    id: number;
    question: string;
    text: string[] | null;
    correctAnswer: string;
    type: QuestionType;
    level: number;
    kp: number;
};


export type MCQ = {
    questionID: number,
    correctOption: number
}

export type MCQOption = {
    questionID: number,
    optionID: number,
    text: string
}

export type Essay = {
    questionID: number,
    reference: string,
    default: string
}

export type Session = {
    sessionID: string,
    score: number,
    from: string,
    to: string
}

export type QuestionInformation = {
    question: Question,
    options: MCQOption[] | string
}