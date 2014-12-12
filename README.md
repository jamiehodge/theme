# Theme

## Installation

`bundle install`

## Usage

`puma`

## Repositories
Place all repositories in `/repositories`

## Routes

### `GET /:repository/:directory`
Returns all documents for the directory
### `GET /:repository/:directory/:document`
Returns the document
### `POST /:repository/:directory/:document`
Updates the document
### `GET /:repository/:directory/:document/parent`
Returns the document's parent revision

(test)
