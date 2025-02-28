const mongoose = require('mongoose');

const usersSchema = new mongoose.Schema({
    username: { type: String },
    email: { type: String, unique: true },
    password: { type: String },
    resetToken: { type: String },
    resetTokenExpiration: { type: Date },
    phoneNumber: { type: Number },
    facebook_id: { type: Number },
    address: {
      addressLine1: { type: String },
      addressLine2: { type: String },
        country: { type: String },
        state: { type: String },
        city: { type: String },
        pincode: { type: String }
    }
});

module.exports = mongoose.model('User', usersSchema);
