package org.example.mevabe.shared.Util;

import org.modelmapper.ModelMapper;
import org.modelmapper.config.Configuration;
import org.modelmapper.convention.MatchingStrategies;

public class MapperUtil {
    private static final ModelMapper modelMapper = new ModelMapper();

    static {
        modelMapper.getConfiguration()
                .setMatchingStrategy(MatchingStrategies.STRICT)
                .setFieldMatchingEnabled(true)
                .setFieldAccessLevel(Configuration.AccessLevel.PRIVATE);
    }

    // dung cho chuc nang add (request -> entity): chua ton tai
    public static <S, D> D map(S source, Class<D> destinationType) {
        return modelMapper.map(source, destinationType);
    }

    /**
     * Dùng cho update: copy field từ source sang object target đã tồn tại
     * Update
     */
    public static <S, T> void mapToExisting(S source, T target) {
        modelMapper.map(source, target);
    }

    public static ModelMapper getModelMapper() {
        return modelMapper;
    }

}
