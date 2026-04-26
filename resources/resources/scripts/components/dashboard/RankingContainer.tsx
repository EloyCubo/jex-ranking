import useSWR from 'swr';
import http from '@/api/http';
import tw from 'twin.macro';
import { breakpoint } from '@/theme';
import * as Icon from 'react-feather';
import React, { useEffect, useState } from 'react';
import styled from 'styled-components/macro';
import Spinner from '@/components/elements/Spinner';
import { Button } from '@/components/elements/button';
import Tooltip from '@/components/elements/tooltip/Tooltip';
import GreyRowBox from '@/components/elements/GreyRowBox';
import ContentBox from '@/components/elements/ContentBox';
import PageContentBlock from '@/components/elements/PageContentBlock';
import { faCoins, faMedal, faCrown, faCalendarAlt, faGift } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const Container = styled.div`
    ${tw`flex flex-wrap`};

    & > div {
        ${tw`w-full`};

        ${breakpoint('sm')`
      width: calc(50% - 1rem);
    `}

        ${breakpoint('md')`
      ${tw`w-auto flex-1`};
    `}
    }
`;

const MedalIcon = styled(FontAwesomeIcon) <{ type: string }>`
    ${tw`text-2xl transition-all duration-300 hover:scale-110 cursor-help`};
    color: ${props => {
        if (props.type === 'gold') return '#FFD700';
        if (props.type === 'silver') return '#C0C0C0';
        if (props.type === 'bronze') return '#CD7F32';
        return '#FFF';
    }};
`;

const StyledGreyRowBox = styled(GreyRowBox)`
    ${tw`bg-neutral-900 flex items-center transition-all duration-200 border-l-2 border-transparent hover:border-neutral-600 hover:bg-neutral-800`};
`;

interface RankingData {
    top10: {
        rank: number;
        username: string;
        balance: number;
        medals: { type: string; name: string }[];
    }[];
    user: {
        rank: number;
        balance: number;
    };
    rewards: string;
    next_month: string;
}

export default () => {
    const { data, error } = useSWR<RankingData>('/api/client/ranking', (url) =>
        http.get(url).then((res) => res.data)
    );
    const [timeLeft, setTimeLeft] = useState('');

    useEffect(() => {
        if (!data) return;

        const interval = setInterval(() => {
            const next = new Date(data.next_month).getTime();
            const now = new Date().getTime();
            const diff = next - now;

            const days = Math.floor(diff / (1000 * 60 * 60 * 24));
            const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((diff % (1000 * 60)) / 1000);

            setTimeLeft(`${days}d ${hours}h ${minutes}m ${seconds}s`);
        }, 1000);

        return () => clearInterval(interval);
    }, [data]);

    if (error) return (
        <PageContentBlock title="Ranking">
            <div className={'bg-red-500/10 border border-red-500/50 p-4 rounded-lg text-red-500'}>
                Error loading ranking: {error.message || 'Unknown error'}
            </div>
        </PageContentBlock>
    );

    if (!data) return <Spinner centered />;

    return (
        <PageContentBlock
            title={'Coin Ranking'}
            description={'Compete to be the user with the most coins of the month and win prizes.'}
        >
            <Container className={'my-10'}>
                <div css={tw`md:flex-[2]`}>
                    <ContentBox title={'User Standings'}>
                        <div className={'flex flex-col gap-2 mt-4'}>
                            {data.top10.map((u, index) => (
                                <StyledGreyRowBox
                                    key={u.username}
                                    css={[index > 0 && tw`mt-2`]}
                                >
                                    <div css={tw`w-10 text-2xl font-bold text-neutral-500 text-center`}>
                                        #{u.rank}
                                    </div>
                                    <div css={tw`ml-4 flex-1 overflow-hidden`}>
                                        <div className={'flex items-center gap-2 text-lg font-bold'}>
                                            {u.username}
                                            {u.rank === 1 && <FontAwesomeIcon icon={faCrown} className={'text-yellow-500 text-sm'} />}
                                            {u.rank === 2 && <FontAwesomeIcon icon={faMedal} className={'text-gray-300 text-sm'} />}
                                            {u.rank === 3 && <FontAwesomeIcon icon={faMedal} className={'text-orange-500 text-sm'} />}
                                        </div>
                                        <p css={tw`text-2xs text-neutral-300 uppercase flex items-center gap-1`}>
                                            <FontAwesomeIcon icon={faCoins} className={'text-neutral-500'} />
                                            {u.balance.toLocaleString()} coins
                                        </p>
                                    </div>
                                    <div className={'flex gap-2'}>
                                        {u.medals.slice(0, 3).map((m, mi) => (
                                            <Tooltip key={mi} content={m.name} placement={'top'}>
                                                <span css={tw`flex items-center justify-center`}>
                                                    <MedalIcon icon={faMedal} type={m.type} />
                                                </span>
                                            </Tooltip>
                                        ))}
                                        {u.medals.length > 3 && (
                                            <div className={'text-neutral-500 text-xs self-center ml-1'}>
                                                +{u.medals.length - 3}
                                            </div>
                                        )}
                                    </div>
                                </StyledGreyRowBox>
                            ))}
                        </div>
                    </ContentBox>
                </div>

                <div css={tw`md:ml-8 mt-8 md:mt-0 flex flex-col gap-8 md:flex-[1]`}>
                    <div className={'grid grid-cols-1 sm:grid-cols-2 gap-4'}>
                        <ContentBox title={'Rewards'}>
                            <div
                                className={'prose prose-invert prose-sm text-neutral-300 mt-2'}
                                dangerouslySetInnerHTML={{ __html: data.rewards }}
                            />
                        </ContentBox>

                        <ContentBox title={'Ends in'}>
                            <div className={'text-2xl font-mono font-bold text-center py-4'}>
                                {timeLeft}
                            </div>
                        </ContentBox>
                    </div>

                    <ContentBox title={'Your Account Status'}>
                        <div className={'flex justify-around items-center py-4'}>
                            <div className={'text-center'}>
                                <div className={'text-neutral-500 text-2xs uppercase'}>Your Rank</div>
                                <div className={'text-4xl font-bold font-mono'}>#{data.user.rank}</div>
                            </div>
                            <div className={'text-center'}>
                                <div className={'text-neutral-500 text-2xs uppercase'}>Your Coins</div>
                                <div className={'text-4xl font-bold font-mono'}>{data.user.balance.toLocaleString()}</div>
                            </div>
                        </div>
                        <div className={'mt-6 flex justify-center'}>
                            <a href={'/store/credits'} className={'w-full'}>
                                <Button size={Button.Sizes.Large} className={'w-full'}>
                                    Get Credits
                                </Button>
                            </a>
                        </div>
                    </ContentBox>
                </div>
            </Container>
        </PageContentBlock>
    );
};
