package vn.mevabe.shop;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Diem khoi dong ung dung.
 *
 * - @EnableAsync: cho phep chay tac vu nen (@Async) - nen tang cho "hang doi" don gian,
 *   sau nay co the thay bang BullMQ/RabbitMQ/Kafka ma khong doi code nghiep vu.
 * - @EnableScheduling: cho phep chay job dinh ky (@Scheduled).
 */
@EnableAsync
@EnableScheduling
@SpringBootApplication
public class MevabeShopApplication {

    public static void main(String[] args) {
        SpringApplication.run(MevabeShopApplication.class, args);
    }
}
