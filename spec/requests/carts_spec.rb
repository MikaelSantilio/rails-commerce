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

      it "returns an error when quantity is invalid" do
        params = {
          product_id: product.id,
          quantity: -1 # Quantidade inválida
        }
        post "/cart/add_item", params: params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Quantidade inválida")
      end

      it "returns an error when product does not in the cart" do
        other_product = FactoryBot.create(:product, name: "Other Product", price: 15.0)
        params = {
          product_id: other_product.id,
          quantity: 1
        }
        post "/cart/add_item", params: params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Dados inválidos")
        expect(json_response["errors"].first).to eq("Produto não está no carrinho")
      end
    end
  end

  describe "POST /cart" do
    let(:product) { FactoryBot.create(:product, name: "Test Product", price: 10.0) }

    it "creates a new cart and returns it" do
      params = {
        product_id: product.id,
        quantity: 2
      }
      post "/cart", params: params, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response["total_price"]).to eq("20.0")
    end

    it "returns an error when product does not exist" do
      params = {
        product_id: 9999, # ID de produto inexistente
        quantity: 2
      }
      post "/cart", params: params, as: :json
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Produto não encontrado")
    end

    it "returns an error when quantity is invalid" do
      params = {
        product_id: product.id,
        quantity: -1 # Quantidade inválida
      }
      post "/cart", params: params, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Quantidade inválida")
    end

    it "returns and error when product is already in the cart" do
      # 1) Inicializa a sessão e captura o cart da sessão
      get "/cart", as: :json
      expect(response).to have_http_status(:ok)
      id = JSON.parse(response.body).fetch("id")
      @session_cart = Cart.find(id)

      # 2) Cria o item no cart da sessão
      @cart_item = FactoryBot.create(:cart_item, cart: @session_cart, product: product, quantity: 1)

      params = {
        product_id: product.id,
        quantity: 1
      }
      post "/cart", params: params, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Dados inválidos")
      expect(json_response["errors"].first).to eq("Produto já está no carrinho")
    end
  end

  describe "DELETE /cart/:product_id" do
    let(:product) { FactoryBot.create(:product, name: "Test Product", price: 10.0) }

    before do
      # 1) Inicializa a sessão e captura o cart da sessão
      get "/cart", as: :json
      expect(response).to have_http_status(:ok)
      id = JSON.parse(response.body).fetch("id")
      @session_cart = Cart.find(id)

      # 2) Cria o item no cart da sessão
      @cart_item = FactoryBot.create(:cart_item, cart: @session_cart, product: product, quantity: 1)
    end

    it "removes the product from the cart" do
      expect {
        delete "/cart/#{product.id}", as: :json
      }.to change { CartItem.count }.by(-1)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response["total_price"]).to eq(0)
    end

    it "returns an error when product is not in the cart" do
      other_product = FactoryBot.create(:product, name: "Other Product", price: 15.0)
      delete "/cart/#{other_product.id}", as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to match(a_string_including("application/json"))

      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Dados inválidos")
      expect(json_response["errors"].first).to eq("Produto não está no carrinho")
    end
  end
end
