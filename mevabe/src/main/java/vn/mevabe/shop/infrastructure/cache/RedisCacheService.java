package vn.mevabe.shop.infrastructure.cache;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Optional;

/**
 * ADAPTER Redis: kich hoat khi app.cache.provider=redis.
 * Cung implements CacheService nen service nghiep vu KHONG can sua gi.
 *
 * Muon dung: bat Redis (docker compose) + dat APP_CACHE_PROVIDER=redis.
 */
@Slf4j
@Service
@ConditionalOnProperty(name = "app.cache.provider", havingValue = "redis")
public class RedisCacheService implements CacheService {

    private final RedisTemplate<String, Object> redisTemplate;

    public RedisCacheService(RedisTemplate<String, Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
        log.info("[Cache] Dang dung RedisCacheService (Redis)");
    }

    @Override
    public void put(String key, Object value, Duration ttl) {
        if (ttl == null) {
            redisTemplate.opsForValue().set(key, value);
        } else {
            redisTemplate.opsForValue().set(key, value, ttl);
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public <T> Optional<T> get(String key, Class<T> type) {
        Object value = redisTemplate.opsForValue().get(key);
        if (value == null) {
            return Optional.empty();
        }
        return Optional.of((T) value);
    }

    @Override
    public void evict(String key) {
        redisTemplate.delete(key);
    }

    @Override
    public void clear() {
        // Trong thuc te nen dung theo prefix/namespace thay vi xoa toan bo.
        var keys = redisTemplate.keys("*");
        if (keys != null && !keys.isEmpty()) {
            redisTemplate.delete(keys);
        }
    }
}
