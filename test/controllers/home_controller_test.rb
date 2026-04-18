require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "root route resolves to home#index" do
    assert_routing "/", controller: "home", action: "index"
  end

  test "health check route is preserved" do
    assert_routing "/up", controller: "rails/health", action: "show"
  end

  test "GET / responds with 200 OK" do
    get "/"
    assert_response :success
  end

  test "GET / renders the page title" do
    get "/"
    assert_select "title", "在庫番 - ホーム"
  end

  test "GET / declares ja lang and light class on html element" do
    get "/"
    assert_select "html[lang=?][class=?]", "ja", "light"
  end

  test "GET / includes viewport and charset meta" do
    get "/"
    assert_select "meta[charset=?]", "utf-8"
    assert_select "meta[name=viewport]"
  end

  test "layout invokes csrf_meta_tags and csp_meta_tag helpers" do
    layout = File.read(Rails.root.join("app/views/layouts/application.html.erb"))
    assert_includes layout, "csrf_meta_tags", "layout must call csrf_meta_tags helper"
    assert_includes layout, "csp_meta_tag", "layout must call csp_meta_tag helper"
  end

  test "GET / loads Tailwind CDN and inline tailwind config" do
    get "/"
    assert_select "script[src*=?]", "cdn.tailwindcss.com"
    assert_select "script#tailwind-config"
    assert response.body.include?("#335278"), "primary color should be configured"
    assert response.body.include?("#48654c"), "secondary color should be configured"
    assert response.body.include?('darkMode: "class"'), "darkMode class should be configured"
    assert response.body.include?("Noto Sans JP"), "fontFamily.sans should reference Noto Sans JP"
  end

  test "GET / loads Noto Sans JP, Plus Jakarta Sans, and Material Symbols" do
    get "/"
    assert_select "link[href*=?]", "Noto+Sans+JP"
    assert_select "link[href*=?]", "Plus+Jakarta+Sans"
    assert_select "link[href*=?]", "Material+Symbols+Outlined"
  end

  test "GET / body uses font-sans class" do
    get "/"
    assert_select "body.font-sans"
  end

  test "GET / renders centered home root container with testid" do
    get "/"
    assert_select "[data-testid=?]", "home-root"
    assert_select "[data-testid=?][class*=?][class*=?]", "home-root", "max-w-md", "mx-auto"
  end

  test "GET / renders the four main home blocks" do
    get "/"
    assert_select "[data-testid=?]", "home-header"
    assert_select "[data-testid=?]", "home-summary"
    assert_select "[data-testid=?]", "home-actions"
    assert_select "[data-testid=?]", "home-bottom-nav"
  end

  test "GET / bottom navigation is a nav with aria-label" do
    get "/"
    assert_select "nav[data-testid=?][aria-label=?]", "home-bottom-nav", "メインナビゲーション"
  end
end
