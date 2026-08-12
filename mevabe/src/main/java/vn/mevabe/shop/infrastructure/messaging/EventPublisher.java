package vn.mevabe.shop.infrastructure.messaging;

/**
 * PORT (cong) phat su kien. Code nghiep vu chi goi publisher.publish(event),
 * KHONG biet ben duoi la ghi log, Kafka, RabbitMQ hay AWS SNS.
 *
 * Doi cong nghe = doi 1 dong config (app.messaging.provider), khong sua service.
 */
public interface EventPublisher {

    void publish(DomainEvent event);
}
