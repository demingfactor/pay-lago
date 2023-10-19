# frozen_string_literal: true

Pay::Engine.routes.draw do
  post "webhooks/lago", to: "pay/webhooks/lago#create" if Pay::Lago.enabled?
end