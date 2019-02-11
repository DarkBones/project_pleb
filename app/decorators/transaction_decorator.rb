class TransactionDecorator < ApplicationDecorator
  delegate_all

  def category
    if model.category
      model.category
    else
      category = Category.new
      category.symbol = "uncategorised"
      category.name = "uncategorised"
      category.color = "6A6C6E";
      return category
    end
  end

  def transfer_message
    if model.transfer_account_id != nil
      message = "Transferred "
      if model.direction == -1
        message += "to "
      else
        message += "from "
      end
      message += Account.find(model.transfer_account_id).name
      return message
    end
    return ""
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
