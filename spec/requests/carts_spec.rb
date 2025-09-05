require "rails_helper"

RSpec.describe "/carts", type: :request do
  describe "POST /add_item" do
    let(:product) { FactoryBot.create(:product, name: "Test Product", price: 10.0) }

    context "when the product already is in the cart" do
      before do
        # 1) Inicializa a sessão e captura o cart da sessão
        get "/cart", as: :json
        expect(response).to have_http_status(:ok)
        id = JSON.parse(response.body).fetch("id")
        @session_cart = Cart.find(id)

        # 2) Cria o item no cart da sessão
        @cart_item = FactoryBot.create(:cart_item, cart: @session_cart, product: product, quantity: 1)
      end

      it "updates the quantity of the existing item in the cart" do
        expect {
          post "/cart/add_item", params: { product_id: product.id, quantity: 1 }, as: :json
          post "/cart/add_item", params: { product_id: product.id, quantity: 1 }, as: :json
        }.to change { @cart_item.reload.quantity }.by(2)
      end
    end
  end
end
