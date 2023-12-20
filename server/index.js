const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const cors = require("cors");
const http = require("http");
const DocumentRouter = require("./routes/document");

const app = express();
const server = http.createServer(app);
// @ts-ignore
const io = require("socket.io")(server);

const port = process.env.port | 3001;
const password = encodeURIComponent("PASSWORD");

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(DocumentRouter);

const DB = `MONGO DB LINK`;
console.log(DB);

mongoose
  .connect(DB)
  .then(function () {
    console.log("connection in DB seccesfulkkl");
  })
  .catch((e) => {
    console.log(e);
  });

  io.on("connection", (socket) => {
    console.log("Socket connected:", socket.id);
  
    socket.on("join", (documentId) => {
      socket.join(documentId);
      console.log(`${socket.id} joined room ${documentId}`);
    });

  socket.on('typing',(data)=>{
    socket.broadcast.to(data.room).emit('changes',data);
  });

  socket.on('save',(data)=>{
    saveData(data);
    
  })
  });

const saveData = async(data)=>{
  let document = await Document.findById(data.room);
  document.content = data.delta;
  document = await document.save();
}

server.listen(port, "0.0.0.0", () => {
  console.log("connected at port " + port);
});
