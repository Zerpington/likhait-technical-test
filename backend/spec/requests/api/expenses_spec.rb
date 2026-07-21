require 'rails_helper'

RSpec.describe "Api::Expenses", type: :request do
  let!(:food_category) { Category.create!(name: "Food") }
  let!(:transport_category) { Category.create!(name: "Transport") }

  describe "GET /api/expenses" do
  let!(:expense1) { Expense.create!(description: "Lunch", amount: 100.00, category: food_category, date: Date.today) }
  let!(:expense2) { Expense.create!(description: "Taxi", amount: 50.00, category: transport_category, date: Date.today) }

    it "returns all expenses with category information" do
      get "/api/expenses"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it "returns expenses in descending order by date, id as tiebreaker" do
      get "/api/expenses"

      json = JSON.parse(response.body)
      expect(json.first["id"]).to eq(expense2.id)
      expect(json.last["id"]).to eq(expense1.id)
    end
  end

  describe "GET /api/expenses?year=&month=" do
    let!(:january_expense) { Expense.create!(description: "New Year Dinner", amount: 40.00, category: food_category, date: Date.new(2026, 1, 15)) }
    let!(:february_expense) { Expense.create!(description: "February Cab", amount: 20.00, category: transport_category, date: Date.new(2026, 2, 1)) }

    it "returns only expenses whose date falls within the requested month" do
      get "/api/expenses", params: { year: 2026, month: 1 }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.map { |e| e["id"] }).to contain_exactly(january_expense.id)
    end

    it "returns only expenses whose date falls within a different requested month" do
      get "/api/expenses", params: { year: 2026, month: 2 }

      json = JSON.parse(response.body)
      expect(json.map { |e| e["id"] }).to contain_exactly(february_expense.id)
    end

    it "filters by the expense's date, not by when the record was created" do
      # Simulates backdating: the expense is entered today but its date belongs to a past month.
      backdated_expense = Expense.create!(
        description: "Backdated rent",
        amount: 500.00,
        category: food_category,
        date: Date.new(2026, 1, 20),
        created_at: Time.current
      )

      get "/api/expenses", params: { year: 2026, month: 1 }
      json = JSON.parse(response.body)
      expect(json.map { |e| e["id"] }).to include(backdated_expense.id)

      get "/api/expenses", params: { year: Time.current.year, month: Time.current.month }
      json = JSON.parse(response.body)
      expect(json.map { |e| e["id"] }).not_to include(backdated_expense.id)
    end
  end

  describe "POST /api/expenses" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          expense: {
            description: "Team Lunch",
            amount: 150.50,
            category_id: food_category.id,
            date: Date.today
          }
        }
      end

      it "creates a new expense" do
        expect {
          post "/api/expenses", params: valid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["description"]).to eq("Team Lunch")
        expect(json["amount"]).to eq(150.5)
      end
    end

    context "with invalid parameters" do
      it "with negative amounts" do
        invalid_params = {
          expense: {
            description: "Invalid expense",
            amount: -100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "with empty descriptions" do
        invalid_params = {
          expense: {
            description: "",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end
end
