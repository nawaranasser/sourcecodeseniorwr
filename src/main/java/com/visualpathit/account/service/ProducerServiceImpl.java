package com.visualpathit.account.service;

import java.nio.charset.StandardCharsets;

import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageProperties;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ProducerServiceImpl implements ProducerService {

    private static final String EXCHANGE_NAME = "messages";

    private final RabbitTemplate rabbitTemplate;

    @Autowired
    public ProducerServiceImpl(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    @Override
    public String produceMessage(String message) {

        Message rabbitMessage = new Message(
                message.getBytes(StandardCharsets.UTF_8),
                new MessageProperties()
        );

        rabbitTemplate.send(
                EXCHANGE_NAME,
                "",
                rabbitMessage
        );

        System.out.println(" [x] Sent '" + message + "'");

        return "response";
    }
}