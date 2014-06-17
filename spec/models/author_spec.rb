require "rails_helper"

describe Author, ".create_or_update_from_payload" do
  it "creates a record" do
    author = Author.create_or_update_from_payload(
      name: "Ada Lovelace",
      email: "ada@lovelace.com",
      username: "adalovelace",
    )

    expect(author).to be_persisted
    expect(author.name).to eq "Ada Lovelace"
    expect(author.email).to eq "ada@lovelace.com"
    expect(author.username).to eq "adalovelace"
  end

  it "updates an existing record by email" do
    author1 = Author.create_or_update_from_payload(
      name: "Ada Lovelace",
      email: "ada@lovelace.com",
      username: "adalovelace",
    )

    author2 = Author.create_or_update_from_payload(
      name: "Other Lovelace",
      email: "ada@lovelace.com",
      username: "otherlovelace",
    )

    author1.reload
    expect(author1.id).to eq(author2.id)
    expect(author1.name).to eq "Other Lovelace"
    expect(author1.email).to eq "ada@lovelace.com"
    expect(author1.username).to eq "otherlovelace"
  end

  it "updates an existing record by username" do
    author1 = Author.create_or_update_from_payload(
      name: "Ada Lovelace",
      email: "ada@lovelace.com",
      username: "adalovelace",
    )

    author2 = Author.create_or_update_from_payload(
      name: "Other Lovelace",
      email: "other@lovelace.com",
      username: "adalovelace",
    )

    author1.reload
    expect(author1.id).to eq(author2.id)
    expect(author1.name).to eq "Other Lovelace"
    expect(author1.email).to eq "other@lovelace.com"
    expect(author1.username).to eq "adalovelace"
  end
end

describe Author, "validations" do
  it "must have at least one property" do
    author = Author.new
    expect(author).not_to be_valid

    author = Author.new(name: "Ada Lovelace")
    expect(author).to be_valid

    author = Author.new(email: "ada@lovelace.com")
    expect(author).to be_valid

    author = Author.new(username: "adalovelace")
    expect(author).to be_valid
  end
end
