package vn.mevabe.shop.infrastructure.cache;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * ADAPTER mac dinh: cache bang bo nho trong (khong can server nao).
 * Kich hoat khi app.cache.provider=memory (hoac khong khai bao).
 *
 * Dung cho luc phat trien / chua co Redis.
 */
@Slf4j
@Service
@ConditionalOnProperty(name = "app.cache.provider", havingValue = "memory", matchIfMissing = true)
public class InMemoryCacheService implements CacheService {

    private record Entry(Object value, Instant expireAt) {
        boolean expired() {
            return expireAt != null && Instant.now().isAfter(expireAt);
        }
    }

    private final Map<String, Entry> store = new ConcurrentHashMap<>();

    public InMemoryCacheService() {
        log.info("[Cache] Dang dung InMemoryCacheService (bo nho trong)");
    }

    @Override
    public void put(String key, Object value, Duration ttl) {
        Instant expireAt = ttl == null ? null : Instant.now().plus(ttl);
        store.put(key, new Entry(value, expireAt));
    }

    @Override
    public <T> Optional<T> get(String key, Class<T> type) {
        Entry entry = store.get(key);
        if (entry == null) {
            return Optional.empty();
        }
        if (entry.expired()) {
            store.remove(key);
            return Optional.empty();
        }
        return Optional.of(type.cast(entry.value()));
    }

    @Override
    public void evict(String key) {
        store.remove(key);
    }

    @Override
    public void clear() {
        store.clear();
    }
}
