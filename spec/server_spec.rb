# frozen_string_literal: true

RSpec.describe Sinatra::Application do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
  let(:example) { File.read('./spec/endpoint_example.json') }

  context 'expected behaviour' do
    describe 'GET /endpoints' do
      it 'list endpoints' do
        get '/endpoints'

        expect(last_response.status).to eq(200)
        expect(json_body['data']).to be_empty
      end
    end

    describe 'POST /endpoints' do
      it 'creates a mock endpoint' do
        post '/endpoints', example, headers
        expect(last_response.status).to eq(201)
        expect(json_body['data']).to have_key('id')
        expect(json_body['data']['id']).not_to be_nil

        get '/endpoints'
        expect(json_body['data'].count).to eq(1)
      end
    end

    describe 'GET /greeting' do
      it 'calls the mocked enpoint' do
        get '/greeting'
        expect(last_response.status).to eq(200)
        expect(json_body['message']).to eq('Hello, world')
      end
    end

    describe 'PATCH /endpoints/id' do
      it 'modifies an existing endpoint' do
        get '/endpoints'
        endpoint_id = json_body['data'][0]['id']
        example2 = File.read('./spec/endpoint_example2.json')
        patch "/endpoints/#{endpoint_id}", example2, headers
        expect(json_body['data']['attributes']['verb']).to eq('POST')
      end
    end

    describe 'POST /greeting' do
      it 'calls the modified mocked enpoint' do
        post '/greeting'
        expect(last_response.status).to eq(200)
        expect(json_body['message']).to eq('Hello, world')
      end
    end

    describe 'DELETE /endpoints/id' do
      it 'deletes an endpoint' do
        get '/endpoints'
        endpoint_id = json_body['data'][0]['id']
        delete "/endpoints/#{endpoint_id}"
        expect(last_response.status).to eq(204)
        get '/endpoints'
        expect(json_body['data']).to be_empty
      end
    end
  end

  context 'errors' do
    describe 'with non-existent endpoints' do
      it 'receives 404' do
        get '/bla'
        expect(last_response.status).to eq(404)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq('Requested endpoint `GET` `/bla` does not exist')
      end
    end

    describe 'trying to PATCH non-existent endpoints' do
      it 'receives 404' do
        patch '/endpoints/bla', headers
        expect(last_response.status).to eq(404)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq('Requested endpoint `PATCH` `/endpoints/bla` does not exist')
      end
    end

    describe 'trying to DELETE non-existent endpoints' do
      it 'receives 404' do
        delete '/endpoints/bla'
        expect(last_response.status).to eq(404)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq('Requested endpoint `DELETE` `/endpoints/bla` does not exist')
      end
    end

    describe 'trying to POST with incorrect information' do
      let(:bad_example) { JSON.parse(example) }
      it 'receives 400 when JSON is malformed' do
        post '/endpoints', '{"}', headers
        expect(last_response.status).to eq(400)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq("unexpected token at '{\"}'")
      end

      it 'receives 400 with missing verb' do
        bad_example['data']['attributes'].delete('verb')
        post '/endpoints', bad_example.to_json, headers
        expect(last_response.status).to eq(400)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq(
          'object at `/data/attributes` is missing required properties: verb'
        )
      end

      it 'receives 400 with missing path' do
        bad_example['data']['attributes'].delete('path')
        post '/endpoints', bad_example.to_json, headers
        expect(last_response.status).to eq(400)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq(
          'object at `/data/attributes` is missing required properties: path'
        )
      end

      it 'receives 400 with missing response' do
        bad_example['data']['attributes'].delete('response')
        post '/endpoints', bad_example.to_json, headers
        expect(last_response.status).to eq(400)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq(
          'object at `/data/attributes` is missing required properties: response'
        )
      end

      it 'receives 400 with missing response code' do
        bad_example['data']['attributes']['response'].delete('code')
        post '/endpoints', bad_example.to_json, headers
        expect(last_response.status).to eq(400)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq(
          'object at `/data/attributes/response` is missing required properties: code'
        )
      end

      it 'receives 400 with an invalid verb' do
        bad_example['data']['attributes']['verb'] = 'BLA'
        post '/endpoints', bad_example.to_json, headers
        expect(last_response.status).to eq(400)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq(
          'value at `/data/attributes/verb` is not one of: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"]'
        )
      end

      it 'receives 400 with an invalid path expression' do
        bad_example['data']['attributes']['path'] = '123'
        post '/endpoints', bad_example.to_json, headers
        expect(last_response.status).to eq(400)
        expect(json_body).to have_key('errors')
        expect(json_body['errors'][0]['detail']).to eq(
          'string at `/data/attributes/path` does not match pattern: ^\\/.*'
        )
      end
    end
  end
end
