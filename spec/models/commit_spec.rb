require "rails_helper"

describe Commit, ".create_or_update_from_payload" do
  let(:parent_payload) {
    {
      ref: "refs/heads/master",
      repository: { name: "myrepo" },
      pusher: { name: "mypusher" },
    }
  }

  it "creates a record with the payload and an identifying SHA hash" do
    commit = Commit.create_or_update_from_payload({
      id: "faa",
      url: "url",
    }, parent_payload)

    expect(commit).to be_persisted
    expect(commit.sha).to eq "faa"
    expect(commit.payload[:url]).to eq "url"
  end

  it "updates an old record if the id is not new" do
    commit = Commit.create_or_update_from_payload({
      id: "faa",
      url: "url1",
    }, parent_payload)

    Commit.create_or_update_from_payload({
      id: "faa",
      url: "url2",
    }, parent_payload)

    commit.reload
    expect(commit.sha).to eq "faa"
    expect(commit.payload[:url]).to eq "url2"
  end

  it "merges in some info from the parent payload" do
    commit = Commit.create_or_update_from_payload({
      id: "faa",
    }, parent_payload)

    expect(commit.payload[:repository][:name]).to eq "myrepo"
    expect(commit.payload[:pusher][:name]).to eq "mypusher"
    expect(commit.payload[:ref]).to eq "refs/heads/master"
  end

  it "creates or updates an author record" do
    commit = Commit.create_or_update_from_payload({
      id: "faa",
      author: {
        name: "Ada Lovelace",
      }
    }, parent_payload)

    expect(commit.author.name).to eq "Ada Lovelace"
  end
end

describe Commit, "#as_json" do
  it "builds a hash of properties" do
    commit = build(:commit, sha: "foo", reviewed_at: Time.now)
    expect(commit.as_json).to include(
      "short_sha" => "foo",
      "reviewed" => true,
    )
  end
end

describe Commit, "#summary" do
  it "truncates the first line of the message to 50 chars" do
    message = "#{"1234567890" * 6}\nMore."

    commit = build(:commit, message: message)

    expect(commit.summary).to eq("1234567890" * 5)
  end
end

describe Commit, "#branch" do
  it "extracts it from the ref" do
    commit = build(:commit, ref: "refs/heads/master")
    expect(commit.branch).to eq "master"
  end
end

describe Commit, "#reviewed?" do
  it "is true if reviewed_at is set" do
    commit = build(:commit, reviewed_at: Time.now)
    expect(commit.reviewed?).to be_truthy
  end
end

describe Commit, "#mark_as_reviewed" do
  it "assigns reviewed_at and persists the record" do
    commit = build(:commit, reviewed_at: nil)

    commit.mark_as_reviewed

    expect(commit).to be_persisted
    expect(commit.reviewed_at).to be_present
  end
end

describe Commit, "#mark_as_unreviewed" do
  it "unassigns reviewed_at and persists the record" do
    commit = build(:commit, reviewed_at: Time.now)

    commit.mark_as_unreviewed

    expect(commit).to be_persisted
    expect(commit.reviewed_at).to be_nil
  end
end
