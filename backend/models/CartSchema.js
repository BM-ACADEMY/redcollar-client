  const mongoose = require('mongoose');

  const addToCartSchema = new mongoose.Schema(
    {
      userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Reference to the user
      product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true }, // Reference to the product
      quantity: { type: Number, required: true, min: 1 }, // Quantity of the product added to the cart
      selected_color: { type: String, required: true }, // Selected color
      selected_size: { type: String, required: true }, // Selected size
      total_price: { type: Number, required: true }, // Total price of the item in the cart
      is_active: { type: Boolean, default: true }, // To mark active or inactive cart
      createdAt: { type: Date, default: Date.now },
      updatedAt: { type: Date, default: Date.now },
    },
    { timestamps: true }
  );

  module.exports = mongoose.model('AddToCart', addToCartSchema);
