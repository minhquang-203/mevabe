package vn.mevabe.shop.infrastructure.messaging;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

/**
 * ADAPTER mac dinh: chi ghi log su kien (khong can Kafka).
 * Kich hoat khi app.messaging.provider=log (hoac khong khai bao).
 *
 * Dung cho luc phat trien de "nhin thay" su kien phat ra.
 */
@Slf4j
@Service
@ConditionalOnProperty(name = "app.messaging.provider", havingValue = "log", matchIfMissing = true)
public class LoggingEventPublisher implements EventPublisher {

    public LoggingEventPublisher() {
        log.info("[Messaging] Dang dung LoggingEventPublisher (chi ghi log)");
    }

    @Override
    public void publish(DomainEvent event) {
        log.info("[EVENT] type={} key={} payload={}", event.type(), event.key(), event.payload());
    }
}
