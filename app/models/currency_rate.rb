# == Schema Information
#
# Table name: currency_rates
#
#  id            :bigint(8)        not null, primary key
#  from_currency :string(255)
#  to_currency   :string(255)
#  rate          :float(24)
#  used_count    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CurrencyRate < ApplicationRecord
  def self.get_rate(from, to)
    currency_rate = self.where(from_currency: from, to_currency: to, updated_at: 1.hours.ago..Time.now).take
    if currency_rate
      rate = currency_rate.rate
    else
      rate = Concurrency.conversion_rate(from, to)
      self.update_rate(from, to, rate)
    end
    return rate
  end

  def self.update_rate(from, to, rate)
    currency_rate = self.where(from_currency: from, to_currency: to).take
    if currency_rate
      currency_rate.rate = rate
      currency_rate.used_count = currency_rate.used_count + 1
      currency_rate.save
    else
      new_rate = self.new
      new_rate.from_currency = from
      new_rate.to_currency = to
      new_rate.rate = rate
      new_rate.used_count = 1
      new_rate.save
    end
  end

  def self.convert(amount, from, to)
    rate = self.get_rate(from.to_s, to.to_s)
        
    amount = amount.to_f / from.subunit_to_unit
    new_amount = amount * rate

    return (new_amount * to.subunit_to_unit).to_i
  end
end