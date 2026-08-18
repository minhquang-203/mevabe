package vn.mevabe.shop.common.util;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import static org.assertj.core.api.Assertions.assertThat;

class CodeGeneratorTest {

    private static final DateTimeFormatter DAY = DateTimeFormatter.ofPattern("yyyyMMdd");

    @Test
    void generate_usesPrefixTodayAndFourCharSuffix() {
        String code = CodeGenerator.generate("CAT");

        assertThat(code).startsWith("CAT-" + LocalDate.now().format(DAY) + "-");
        assertThat(code).matches("CAT-\\d{8}-[A-HJ-NP-Z2-9]{4}");
    }
}
