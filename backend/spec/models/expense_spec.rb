require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:category) { Category.create!(name: "Food") }

  describe "date validation" do
    it "is valid with today's date" do
      expense = Expense.new(description: "Lunch", amount: 10.00, category: category, date: Date.current)

      expect(expense).to be_valid
    end

    it "is valid with a past date" do
      expense = Expense.new(description: "Lunch", amount: 10.00, category: category, date: Date.current - 1)

      expect(expense).to be_valid
    end

    it "is invalid with a future date" do
      expense = Expense.new(description: "Lunch", amount: 10.00, category: category, date: Date.current + 1)

      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to include("cannot be in the future")
    end
  end
end
