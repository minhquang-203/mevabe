package vn.mevabe.shop.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

/**
 * Hang doi tac vu nen (thread pool) cho cac viec chay @Async
 * nhu: gui email, ghi log, day thong bao...
 *
 * Day la "hang doi" don gian trong 1 tien trinh. Khi can quy mo lon hon
 * (nhieu server, dam bao khong mat viec), ta thay bang RabbitMQ/Kafka
 * ma KHONG doi cach goi @Async o tang service.
 */
@Configuration
public class AsyncConfig {

    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(4);
        executor.setMaxPoolSize(16);
        executor.setQueueCapacity(500);
        executor.setThreadNamePrefix("mevabe-async-");
        executor.initialize();
        return executor;
    }
}
