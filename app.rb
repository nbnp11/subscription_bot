require 'telegram/bot'
require 'redis'
require 'pry'

TOKEN = '6327313015:AAHvCUTfp8nchxAEeizY1cCvVE_ZDz_ZrM4'

  pp '----------------'
  pp 'starting tg bot....'
  # redis = Redis.new

Telegram::Bot::Client.run(TOKEN) do |bot|
  pp 'bot started!'
  pp '----------------'
  bot.listen do |message|

    pp '----------------'
    pp message
    pp '----------------'

    if message.is_a?(Telegram::Bot::Types::CallbackQuery) && message.data == 'check'
      user_id = message.from.id
      # result = redis.get(user_id)

      pp result

      # if result == 'subscribed'
      #   bot.api.send_message(chat_id: message.from.id, text: "Вы уже воспользовались промо-кодом")
      # else
      begin
        # my channel -1001984875682
        # glassnaya -1001195620030
        response = bot.api.get_chat_member(chat_id: -1001195620030, user_id: user_id)

        pp '----------------'
        pp response
        pp '----------------'

        if response['ok'] && response['result']['status'] != 'left'
          redis.set(user_id, 'subscribed')
          bot.api.send_message(chat_id: message.from.id, text: "Ваш промо код: GLASSNAYA2023")
        else
          bot.api.send_message(chat_id: message.from.id, text: "Ошибка, вы не подписаны на канал")
          redis.set(user_id, 'unsubscribed')
        end
      rescue Telegram::Bot::Exceptions::ResponseError
        bot.api.send_message(chat_id: message.from.id, text: "Ошибка, вы не подписаны на канал")
        redis.set(user_id, 'unsubscribed')
      end
      # end
    elsif message.is_a?(Telegram::Bot::Types::Message) && message.text == '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    else
      greeting = 'Что бы получить скидку 10% на первый заказ подпишитесь на канал и нажмите кнопку "Получить промокод🥳".'

      subscribe_button = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Подписаться на "GLASSNAYA"', url: 'https://t.me/+GOzCDwkfFzkwOTMy')
      get_promo_button = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Получить промокод🥳', callback_data: 'check')
      keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(
        inline_keyboard: [
          [subscribe_button], [get_promo_button]
        ],
        one_time_keyboard: true
      )

      bot.api.send_message(chat_id: message.chat.id, text: greeting, reply_markup: keyboard)
    end
  end
rescue Exception => e
  pp '----------------'
  pp e
  pp '----------------'

  exit 0
end
