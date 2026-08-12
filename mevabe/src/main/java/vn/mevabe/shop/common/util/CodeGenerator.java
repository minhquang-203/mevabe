package vn.mevabe.shop.common.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Sinh ma nghiep vu *_code (vi du: CAT-20260813-AB12).
 * DB dung *_code lam khoa nghiep vu duy nhat, nen moi khi tao ban ghi moi
 * ta sinh ma o day.
 */
public final class CodeGenerator {

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final String ALPHANUM = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    private CodeGenerator() {
    }

    public static String generate(String prefix) {
        String date = LocalDateTime.now().format(DATE);
        return prefix + "-" + date + "-" + randomSuffix(4);
    }

    private static String randomSuffix(int length) {
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(ALPHANUM.charAt(ThreadLocalRandom.current().nextInt(ALPHANUM.length())));
        }
        return sb.toString();
    }
}
