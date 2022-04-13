require 'spec_helper'

describe Spree::Promotion::Actions::BuyOneGetHalf, type: :model do
  let(:order) {  create(:order_with_line_item_quantity, line_items_quantity: 2) }
  let(:promotion) { create(:promotion) }
  let(:action) { Spree::Promotion::Actions::BuyOneGetHalf.create }
  let(:payload) { { order: order, promotion: promotion } }

  it_behaves_like 'an adjustment source'

  # From promotion spec:
  context '#perform' do
    before do
      promotion.promotion_actions << action
    end

    it 'it reduces the price of other line_item by half' do
       expect(action.perform(payload)).to be true
       expect(order.line_items.first.quantity).to eq(2)
       expect(order.line_items.first.reload.adjustments.first.amount.to_f).to eq(-order.line_items.first.price.to_f/2)
    end
  end
end
