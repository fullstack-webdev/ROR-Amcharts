# Be sure to restart your server when you modify this file.

# ElephantWebApp::Application.config.session_store :cookie_store, key: '_elephant_web_app_session', expire_after: 5.days

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
ElephantWebApp::Application.config.session_store :active_record_store, {
    expire_after: 5.days,
}
