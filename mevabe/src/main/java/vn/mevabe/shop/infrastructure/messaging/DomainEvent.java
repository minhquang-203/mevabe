package vn.mevabe.shop.infrastructure.messaging;

import java.time.Instant;

/**
 * Su kien nghiep vu (vi du: OrderCreated, StockChanged...).
 * - type: ten su kien, dung lam ten topic khi ban qua Kafka.
 * - key: khoa phan hoach (vi du order_code) de dam bao thu tu.
 * - payload: du lieu di kem (thuong la 1 DTO).
 */
public record DomainEvent(String type, String key, Object payload, Instant occurredAt) {

    public static DomainEvent of(String type, String key, Object payload) {
        return new DomainEvent(type, key, payload, Instant.now());
    }
}
