module Scrooge::Actions

  class ListAccounts
    def initialize(repository, renderer)
      @repository = repository
      @renderer = renderer
    end

    def call
      body = @renderer.render(@repository.all)
      [200, [body]]
    end
  end

  class ShowAccount
    def initialize(repository, renderer)
      @repository = repository
      @renderer = renderer
    end

    def call(id)
      account = @repository.get(id.to_i) or return [404, []]
      body = @renderer.render(account)
      [200, [body]]
    end
  end

  class UpdateAccount
    def initialize(repository, renderer)
      @repository = repository
      @renderer = renderer
    end

    def call(id, params)
      account = @repository.get(id.to_i) or return [404, []]

      set_attributes!(account, filter_params(params))
      if @repository.update(account)
        body = @renderer.render(account)
        [200, [body]]
      else
        [406, []]
      end
    end

    private

    def include_key?(list, key)
      list.include?(key.to_s) || list.include?(key.to_sym)
    end

    def filter_params(params, white_list = @repository.attributes)
      params.reject { |key, value| !include_key?(white_list, key) }
    end

    def set_attributes!(object, attributes)
      attributes.each do |attribute, value|
        object.send("#{attribute}=", value)
      end
    end
  end

  class CreateAccount
    def initialize(repository, renderer)
      @repository = repository
      @renderer = renderer
    end

    def call(params)
      params = filter_params(params)
      account = @repository.create(params)

      if account
        body = @renderer.render(account)
        [201, [body]]
      else
        [406, []]
      end
    end

    private

    def include_key?(list, key)
      list.include?(key.to_s) || list.include?(key.to_sym)
    end

    def filter_params(params, white_list = @repository.attributes)
      params.reject { |key, value| !include_key?(white_list, key) }
    end
  end

  class DeleteAccount
    def initialize(repository, renderer)
      @repository = repository
      @renderer = renderer
    end

    def call(id)
      account = @repository.get(id.to_i) or return [404, []]

      if @repository.destroy(account)
        body = @renderer.render(account)
        [200, [body]]
      else
        [406, []]
      end
    end
  end
end
