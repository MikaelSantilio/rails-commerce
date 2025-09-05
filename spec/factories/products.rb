FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    price do
      base = rand(10..10000)
      cents = [0, 50, 90].sample # finais comuns em preços
      "#{base}.#{cents}".to_f
    end
  end
end
