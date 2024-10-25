# Obrigado pela oportunidade!
# Espero que goste do conteúdo! :)

require 'rspec'
require_relative 'price_service'

RSpec.describe PriceService do
  subject(:call) { PriceService.new(product: product, user: user).call }

  let(:product) { { id: 1, base_price: 100, tax_percentage: 0 } }
  let(:user) { { id: 1, birthday_month: 5 } }

  it 'calculates the total price' do
    # Removi a variável não utilizada que estava sendo aplicada aqui.
    expect(call).to eq(100.0)
  end

  context 'when product has tax' do
    let(:product) { { id: 1, base_price: 100, tax_percentage: tax_percentage } }

    context 'with 0% tax' do
      let(:tax_percentage) { 0 }
      it { expect(call).to eq(100) }
    end

    context 'with 5% tax' do
      let(:tax_percentage) { 5 }
      it { expect(call).to eq(105) }
    end

    context 'with 20% tax' do
      let(:tax_percentage) { 20 }
      it { expect(call).to eq(120) }
    end
  end

  context 'when taxes are not accountable' do
    before { stub_const('TAX_ACCOUNTABLE', false) }

    let(:product) { { id: 1, base_price: 100, tax_percentage: 10 } }

    # Assumo que pensar em uma situação pra esse carinha passar
    # foi o maior desafio. hahahahaha
    it 'ignores the taxes' do
      expect(call).to eq(100)
    end
  end

  context 'when product category has discount' do
    let(:product) { { id: 1, base_price: 100, tax_percentage: 0, category: 'food' } }

    it 'applies a 5% discount' do
      expect(call).to eq(95)
    end
  end

  context 'when product category has no discount' do
    let(:product) { { id: 1, base_price: 100, tax_percentage: 10, category: 'non-food' } }

    it 'return full price' do
      expect(call).to eq(110)
    end
  end

  context 'when its the users birthday month' do
    let(:user) { { id: 1, birthday_month: Date.today.month } }

    it 'applies a 10% discount' do
      expect(call).to eq(90)
    end
  end

  context 'when it is not the users birthday month' do
    let(:user) { { id: 1, birthday_month: Date.today.month - 1 } }

    it 'does not apply a birthday discount' do
      expect(call).to eq(100.0)
    end
  end

  context 'when both category and birthday discounts are stackable' do
    let(:product) { { id: 1, base_price: 100, tax_percentage: 10, category: 'beverages' } }
    let(:user) { { id: 1, birthday_month: Date.today.month } }

    it 'applies the sum of discounts' do
      expect(call).to eq(93.5)
    end
  end

  context 'when only the higher discount applies' do
    before { stub_const('STACKABLE_DISCOUNT', false) }

    let(:product) { { id: 1, base_price: 100, tax_percentage: 10, category: 'food' } }
    let(:user) { { id: 1, birthday_month: Date.today.month } }

    it 'applies the higher discount only' do
      expect(call).to eq(99)
    end
  end

  context 'when discounts exceeds base price' do
    before { stub_const('BIRTHDAY_MONTH_DISCOUNT', 100) }

    let(:product) { { id: 1, base_price: 100, tax_percentage: 0, category: 'food' } }
    let(:user) { { id: 1, birthday_month: Date.today.month } }

    it 'does not return a negative price' do
      expect(call).to eq(0.0)
    end
  end
end
