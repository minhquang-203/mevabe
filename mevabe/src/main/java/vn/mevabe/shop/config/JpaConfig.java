package vn.mevabe.shop.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * Bat JPA Auditing de @CreatedDate / @LastModifiedDate trong BaseEntity tu dong hoat dong.
 */
@Configuration
@EnableJpaAuditing
public class JpaConfig {
}
