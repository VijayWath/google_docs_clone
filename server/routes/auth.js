const express = require("express");
const User = require("../models/user");
const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");
const auth = require("../middleware/auth");

const authRouter = express.Router();

authRouter.post("/api/signup", async (req, res) => {
  try {
    const { name, email, profilePicture } = req.body;
    let user = await User.findOne({ email });
    if (!user) {
      // user = new User({
      //     email:email,
      //     profilePicture:profilePicture,
      //     name:name
      // });
      user = new User({
        email,
        profilePicture,
        name,
      });
      user = await user.save();
    }

  const token =  jwt.sign({id:user._id},"passwordKey");

    res.json({ user , token });

  } catch (error) {
    console.log(error);
    res.status(500).json({error:error.message});
  }
});

authRouter.get('/',auth,async(req,res)=>{

 const  user =await User.findById(req.user);
 res.json({user,token:req.token});
})

module.exports = authRouter;