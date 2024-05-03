let content = [
  './app/views/**/*.html.erb',
  './app/views/**/*.html.slim',
  './app/views/**/*.html+*.erb',
  './app/views/**/*.html+*.slim',
  './app/helpers/**/*.rb',
  './app/components/**/*.html.erb',
  './app/components/**/*.html.slim',
  './app/components/**/*.rb',
  './app/javascript/**/*.js'
]

if (process.env.RAILS_ENV == "production") {
  content.push(
    '!./app/components/**/previews/*.html.erb',
    '!./app/components/**/previews/*.html.slim'
  )
} else {
  content.push(
    './spec/components/previews/**/*.rb',
    './spec/components/previews/**/*.html.slim',
    './spec/components/previews/**/*.html.erb'
  )
}

module.exports = {
  content: content
}
