require "rails_helper"

describe "Heroku webhooks", :js do
  it "causes a reload if client version is different from server version" do
    set_server_version "1.0"

    visit "/"
    expect_client_version "1.0"

    # Webhook happens when a new version is around?
    # Force a reload!

    set_server_version "2.0"
    expect_page_to_reload do
      the_heroku_webhook_is_triggered
    end
    expect_client_version "2.0"

    # Webhook happens when the version hasn't changed?
    # Don't reload.

    expect_page_not_to_reload do
      the_heroku_webhook_is_triggered
    end
  end

  private

  def expect_page_not_to_reload
    watch_for_page_reloads
    yield
    allow_time_for_a_reload_to_happen
    expect(page.evaluate_script("window.notReloaded")).to be_truthy
  end

  def expect_page_to_reload
    watch_for_page_reloads
    yield
    allow_time_for_a_reload_to_happen
    expect(page.evaluate_script("window.notReloaded")).to be_falsy
  end

  def watch_for_page_reloads
    page.evaluate_script "window.notReloaded = true"
  end

  def allow_time_for_a_reload_to_happen
    sleep 0.01  # Sadly, we need this.
  end

  def the_heroku_webhook_is_triggered
    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.post("/heroku_webhook")
  end

  def set_server_version(num)
    allow(Remit).to receive(:version).and_return(num)
  end

  def expect_client_version(num)
    meta = find("meta[name=version]", visible: false)
    expect(meta[:content]).to eq(num)
  end
end
