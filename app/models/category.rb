class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_one :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

  def self.get_user_categories(current_user, as_array=false, use_levels=false)
    if as_array
      tree = Hash.new { |h,k| h[k] = { :name => nil, :children => [ ] } }

      tree[0][:id] = 0
      tree[0][:name] = "Uncategorised"
      tree[0][:color] = "0, 0%, 50%"
      tree[0][:symbol] = "uncategorised"
      tree[nil][:children].push(tree[0])

      current_user.categories.order(:name).each do |cat|
        tree[cat.id][:id] = cat.id
        tree[cat.id][:name] = cat[:name]
        tree[cat.id][:color] = cat[:color]
        tree[cat.id][:symbol] = cat[:symbol]
        tree[cat.parent_id][:children].push(tree[cat.id])
      end
      
      return tree[nil][:children]
    else
      return current_user.categories
    end
  end

  def self.get_uncategorised
    cat = Category.new
    cat.id = 0
    cat.name = 'Uncategorised'
    cat.color = '0, 0%, 50%'
    cat.symbol = 'uncategorised'
    return cat
  end

end
