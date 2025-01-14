# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CaskyBudget.Repo.insert!(%CaskyBudget.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias CaskyBudget.Accounts
alias CaskyBudget.Accounts.Organization
alias CaskyBudget.Accounts.User
alias CaskyBudget.Budgets.Receipt
alias CaskyBudget.Repo
alias CaskyBudget.Budgets.{Budget, Category, SubCategory}

# Create a budget for the year 2024
budget_2024 =
  Repo.insert!(%Budget{
    year: 2024
  })

budget_2025 =
  Repo.insert!(%Budget{
    year: 2025
  })

{:ok, organization} =
  Repo.insert(%Organization{
    name: "Casky Baptist",
    address_line_one: "4090 Casky Lane",
    city: "Hopkinsville",
    state: "KY",
    postal_code: "42240",
    image_url: "meow.com",
    phone_number: "1-270-111-2222"
  })

IO.inspect(organization)

users =
  for i <- 1..400 do
    {:ok, user} =
      Repo.insert(%User{
        email: "dummyuser#{i}@example.com",
        hashed_password: Bcrypt.hash_pwd_salt("dummyhashedpassword"),
        first_name: "Test#{i}",
        last_name: "User#{i}",
        address_line_one: "101 main st",
        postal_code: "37042",
        city: "Clarksville",
        state: "TN",
        phone: "615-521-7657",
        organization_id: organization.id
      })

    Accounts.associate_user_with_organization(user.id, organization.id)

    user
  end

{:ok, my_user} =
  Repo.insert(%User{
    email: "test@test.com",
    hashed_password: Bcrypt.hash_pwd_salt("422993Jp422993jp"),
    first_name: "Test",
    last_name: "User",
    address_line_one: "101 main st",
    postal_code: "37042",
    city: "Clarksville",
    state: "TN",
    phone: "615-521-7657",
    organization_id: organization.id
  })

Accounts.associate_user_with_organization(my_user.id, organization.id)
# Insert categories and subcategories
categories = [
  %{
    name: "missions",
    subcategories: [
      %{name: "Adullam Missions", amount_approved: Decimal.new(2000)},
      %{name: "Community Missions", amount_approved: Decimal.new(1500)},
      %{name: "Short-Term Missions", amount_approved: Decimal.new(1800)},
      %{name: "Missions Training", amount_approved: Decimal.new(1200)}
    ]
  },
  %{
    name: "staff",
    subcategories: [
      %{name: "Pastoral Staff", amount_approved: Decimal.new(5000)},
      %{name: "Admin Staff", amount_approved: Decimal.new(3500)},
      %{name: "Ministry Staff", amount_approved: Decimal.new(4200)},
      %{name: "Staff Training", amount_approved: Decimal.new(1500)}
    ]
  },
  %{
    name: "facilities",
    subcategories: [
      %{name: "Building Maintenance", amount_approved: Decimal.new(3000)},
      %{name: "Utilities", amount_approved: Decimal.new(2500)},
      %{name: "Repairs", amount_approved: Decimal.new(1800)},
      %{name: "Security", amount_approved: Decimal.new(1200)}
    ]
  },
  %{
    name: "ministry",
    subcategories: [
      %{name: "Children's Ministry", amount_approved: Decimal.new(2000)},
      %{name: "Youth Ministry", amount_approved: Decimal.new(1800)},
      %{name: "Small Groups", amount_approved: Decimal.new(1500)},
      %{name: "Discipleship", amount_approved: Decimal.new(1200)}
    ]
  },
  %{
    name: "administration",
    subcategories: [
      %{name: "Office Supplies", amount_approved: Decimal.new(800)},
      %{name: "Software & Technology", amount_approved: Decimal.new(1500)},
      %{name: "Legal & Professional", amount_approved: Decimal.new(1200)},
      %{name: "Insurance", amount_approved: Decimal.new(1000)}
    ]
  },
  %{
    name: "local outreach",
    subcategories: [
      %{name: "Community Events", amount_approved: Decimal.new(1500)},
      %{name: "Local Partnerships", amount_approved: Decimal.new(1200)},
      %{name: "Benevolence Fund", amount_approved: Decimal.new(1800)},
      %{name: "Outreach Programs", amount_approved: Decimal.new(1500)}
    ]
  }
]

Enum.each(categories, fn category ->
  # Insert category
  budgets = [budget_2024, budget_2025]

  Enum.each(budgets, fn budget ->
    new_category =
      Repo.insert!(%Category{
        name: category.name,
        budget_id: budget.id
      })

    # Insert subcategories
    Enum.each(category.subcategories, fn subcategory ->
      new_subcategory =
        Repo.insert!(%SubCategory{
          name: subcategory.name,
          amount_approved: subcategory.amount_approved,
          category_id: new_category.id
        })

      # Create 10 receipts for the subcategory with randomized fields
      Enum.each(1..200, fn _ ->
        is_approved = Enum.random([true, false])

        Repo.insert!(%Receipt{
          amount: Decimal.new(Enum.random(10..20)),
          receipt_date:
            Enum.random(
              Date.range(
                Date.new!(budget.year, 1, 1),
                Date.new!(budget.year, 12, 31)
              )
            ),
          is_personal_payment: Enum.random([true, false]),
          business_name: "Amazon",
          is_approved: is_approved,
          is_paid: if(is_approved, do: Enum.random([true, false]), else: false),
          check_is_cleared: if(is_approved, do: Enum.random([true, false]), else: false),
          check_number: if(is_approved, do: "CHK#{Enum.random(1000..9999)}", else: nil),
          file_path: "/receipts/receipt_#{Enum.random(1000..9999)}.pdf",
          uploaded_by_user_id: Enum.random(users).id,
          sub_category_id: new_subcategory.id
        })
      end)
    end)
  end)
end)

IO.puts("2024 budget seed data inserted successfully!")
