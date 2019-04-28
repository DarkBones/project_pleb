# == Schema Information
#
# Table name: scheduled_transactions
#
#  id                  :bigint(8)        not null, primary key
#  user_id             :bigint(8)
#  amount              :integer
#  direction           :integer
#  description         :string(255)
#  account_id          :bigint(8)
#  currency            :string(255)
#  category_id         :bigint(8)
#  parent_id           :bigint(8)
#  transfer_account_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class ScheduledTransaction < ApplicationRecord
  has_and_belongs_to_many :schedules
end
