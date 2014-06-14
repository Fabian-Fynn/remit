namespace :dev do
  desc "Send ENV['N'] (default: 1) fake commits by webhook"
  task :commits => :environment do
    count = ENV["N"].to_i.nonzero? || 1
    puts "Sending #{count} fake #{count == 1 ? "commit" : "commits"} to the webhook…"

    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.post "/github_webhook",
      {
        commits: Array.new(count) { FactoryGirl.commit_payload },
        repository: { name: "fakerepo" },
        pusher: { name: "fakepusher" },
      },
      { "X-Github-Event" => "push" }

    body = session.response.body
    p "Server responds: #{body}"
  end
end
