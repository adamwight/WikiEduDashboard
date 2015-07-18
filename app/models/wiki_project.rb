class WikiProject < ActiveRecord::Base
  def article_url(language, title)
    "https://#{language}.#{@article_path}#{title}"
  end

  def script_url(language, script)
    "https://#{language}.#{@script_path}#{script}"
  end

  def api_url(language)
    script_url(language, "api.php")
  end
end
