package vn.mevabe.shop.infrastructure.cache;

import java.time.Duration;
import java.util.Optional;

/**
 * PORT (cong) cho cache. Code nghiep vu chi phu thuoc interface nay,
 * KHONG biet ben duoi la Redis hay bo nho trong.
 *
 * Doi cong nghe cache = doi 1 dong config (app.cache.provider), khong sua service.
 */
public interface CacheService {

    void put(String key, Object value, Duration ttl);

    <T> Optional<T> get(String key, Class<T> type);

    void evict(String key);

    void clear();
}
