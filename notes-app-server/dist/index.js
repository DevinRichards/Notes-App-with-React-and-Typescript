"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const path_1 = __importDefault(require("path"));
const client_1 = require("@prisma/client");
const dotenv_1 = __importDefault(require("dotenv"));
// Load environment variables from .env file
dotenv_1.default.config();
const app = (0, express_1.default)();
app.use(express_1.default.json());
app.use((0, cors_1.default)());
const prisma = new client_1.PrismaClient({
    datasources: {
        db: {
            url: process.env.DATABASE_URL,
        },
    },
});
// Serve the frontend
app.use(express_1.default.static(path_1.default.join(__dirname, "../../notes-app-ui/build")));
app.get("/", (req, res) => {
    res.sendFile(path_1.default.join(__dirname, "../../notes-app-ui/build", "index.html"));
});
app.get("/api/notes", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    res.json({ message: "success!" });
}));
app.get("/notes", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const notes = yield prisma.note.findMany();
    res.json(notes);
}));
app.post("/notes", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { title, content } = req.body;
    if (!title || !content) {
        return res.status(400).send("title and content fields required");
    }
    try {
        const note = yield prisma.note.create({
            data: { title, content },
        });
        res.json(note);
    }
    catch (error) {
        res.status(500).send("Oops! Something went Wrong");
    }
}));
app.put("/notes/:id", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { title, content } = req.body;
    const id = parseInt(req.params.id);
    if (!title || !content) {
        return res.status(400).send("title and content fields required");
    }
    if (!id || isNaN(id)) {
        return res.status(400).send("ID must be a valid number");
    }
    try {
        const updatedNote = yield prisma.note.update({
            where: { id },
            data: { title, content },
        });
        res.json(updatedNote);
    }
    catch (error) {
        res.status(500).send("Oops, something went wrong");
    }
}));
app.delete("/notes/:id", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const id = parseInt(req.params.id);
    if (!id || isNaN(id)) {
        return res.status(400).send("ID field required");
    }
    try {
        yield prisma.note.delete({
            where: { id },
        });
        res.status(204).send();
    }
    catch (error) {
        res.status(500).send("Oops, something went wrong");
    }
}));
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
