require 'date'

# Eu adicionei essas variáveis globais para simular uma environment flag
# evitando que tenhamos valores hard coded.
# Então, por favor, finja que essa parte aqui é um `.env`
CATEGORY_DISCOUNT = 5
BIRTHDAY_MONTH_DISCOUNT = 10

# Adicionei esse 'stackável' para situações que teríamos alguma ação que
# pudesse juntar os descontos, ou não. Caso não seja aplicável tal situação
# usaremos o maior desconto.
STACKABLE_DISCOUNT = true

# Adicionei esta variável considerando que poderíamos ter alguma
# ação promocional que estaríamos cobrindo o imposto do usuário, por exemplo.
TAX_ACCOUNTABLE = true

class PriceService
  attr_reader :product, :user

  def initialize(product:, user:)
    @product = product
    @user = user
    @allowed_categories = %w[food beverages]
  end

  def call
    final_price
  end

  private

  def base_price
    product[:base_price]
  end

  def final_price
    total_amount = taxed_price - discount_amount
    total_amount.positive? ? total_amount : 0
  end

  def tax_amount
    base_price * (product[:tax_percentage] / 100.0)
  end

  def taxed_price
    TAX_ACCOUNTABLE ? (base_price + tax_amount) : base_price
  end

  def category_discount
    @allowed_categories.include?(product[:category]) ? CATEGORY_DISCOUNT : 0
  end

  def birthday_month_discount
    user[:birthday_month] == Date.today.month ? BIRTHDAY_MONTH_DISCOUNT : 0
  end

  def higher_discount
    [category_discount, birthday_month_discount].max
  end

  def discount_amount
    total_discount = STACKABLE_DISCOUNT ? (category_discount + birthday_month_discount) : higher_discount
    taxed_price * (total_discount / 100.0)
  end
end
