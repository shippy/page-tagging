# PageTagger
PageTagger is a simple application that allows collaborative tag assignment to collections of URLs. It keeps track of permitted tags and users who tagged the URLs last.

It is database-agnostic, and will work with every database compatible with ActiveRecord.

## Setup
PageTagger interfaces with a database; consequently, you will need to create `config/database.yml` and edit relevant details in `config/environments.rb`.

To set up the database, call `rake db:create && rake db:migrate`.

(Currently, test database initialization is broken; `rake db:test:prepare` only creates an sqlite3 `db/test.db` file, but fails to populate it. The workaround is to create the table manually, as documented in [issue #26](https://github.com/shippy/page-tagging/issues/26).)

Currently, tags are hard-coded in `app.rb` as `options`, among `helpers`. That is where you can change them.

Now, when you run `rackup config.ru -p 4567`, PageTagger will be available at http://localhost:4567/.

## Import
Since no pages exist to be tagged, PageTagger will redirect you to `/import` to import some. It will expect a newline-separated list of URLs. You can either paste it in the textarea, or upload as a file.

You can import more URLs at any point.

## Tagging
### First round
Root page `/` will sequentially display every page that allows iframe embedding and allow the user to select the most appropriate tag. (Some pages cannot be loaded due to X-Frame-Options Same Origin restriction.)

### Listing
`/list` contains a list of URLs grouped by their assigned tag.

### Re-tagging
`/tag/:tag` allows users to step randomly through all sites with a given tag and confirm/re-tag them.

## Export
PageTagger uses JSON export. There are three options:

- `/export` will export all URLs, tagged or not;
- `/export/:tag` will export all URLs tagged as `:tag`;
- `/export-except/:tag` will export all URLS except those tagged as `:tag`.

## Others
`/stats` contains a ranking of users by number of pages each user tagged.
