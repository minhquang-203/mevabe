package vn.mevabe.shop.infrastructure.messaging;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

/**
 * ADAPTER Kafka: kich hoat khi app.messaging.provider=kafka.
 * Cung implements EventPublisher nen service nghiep vu KHONG can sua gi.
 *
 * Ten topic = <topic-prefix>.<event.type>  (vi du: mevabe.OrderCreated)
 */
@Slf4j
@Service
@ConditionalOnProperty(name = "app.messaging.provider", havingValue = "kafka")
public class KafkaEventPublisher implements EventPublisher {

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    @Value("${app.messaging.topic-prefix:mevabe}")
    private String topicPrefix;

    public KafkaEventPublisher(KafkaTemplate<String, String> kafkaTemplate, ObjectMapper objectMapper) {
        this.kafkaTemplate = kafkaTemplate;
        this.objectMapper = objectMapper;
        log.info("[Messaging] Dang dung KafkaEventPublisher (Kafka)");
    }

    @Override
    public void publish(DomainEvent event) {
        String topic = topicPrefix + "." + event.type();
        try {
            String json = objectMapper.writeValueAsString(event.payload());
            kafkaTemplate.send(topic, event.key(), json);
        } catch (JsonProcessingException e) {
            log.error("[Messaging] Loi serialize su kien {}", event.type(), e);
        }
    }
}
