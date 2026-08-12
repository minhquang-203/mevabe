package vn.mevabe.shop.infrastructure.cache;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * Chi tao RedisTemplate<String,Object> khi thuc su bat Redis (app.cache.provider=redis).
 * Luu key dang chuoi, value dang JSON.
 */
@Configuration
@ConditionalOnProperty(name = "app.cache.provider", havingValue = "redis")
public class RedisConfig {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory,
                                                       ObjectMapper objectMapper) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);
        template.setKeySerializer(new StringRedisSerializer());
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer(objectMapper));
        template.setHashValueSerializer(new GenericJackson2JsonRedisSerializer(objectMapper));
        template.afterPropertiesSet();
        return template;
    }
}
