const express = require("express");
const Document = require("../models/document");
const auth = require("../middleware/auth");
const cors = require("cors");

const DocumentRouter = express.Router();

DocumentRouter.use(cors());

DocumentRouter.post("/docs/create", auth, async (req, res) => {
  try {
    const { createdAt } = req.body;
    let document = new Document({
      uid: req.user,
      title: "untitled Document",
      createdAt,
    });
    document = await document.save();
    res.json(document);
  } catch (e) {
    console.log(error);
    res.status(500).json({ error: error.message });
  }
});

DocumentRouter.get("/docs/me", auth, async (req, res) => {
  try {
    let document = await Document.find({ uid: req.user });
    res.json(document);
    // console.log(document);
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: error.message });
  }
});

DocumentRouter.post("/docs/title", auth, async (req, res) => {
  try {
    const { id, title } = req.body;
    const document = await Document.findByIdAndUpdate(id, { title });

    res.json(document);
  } catch (e) {
    console.log(error);
    res.status(500).json({ error: error.message });
  }
});

DocumentRouter.get("/docs/:id", auth, async (req, res) => {
  try {
    let document = await Document.findById(req.params.id);
    res.json(document);
    // console.log("TITLE CHANGED DOCUMENT"+document);
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = DocumentRouter;
